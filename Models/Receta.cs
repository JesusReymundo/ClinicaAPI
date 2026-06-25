using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Receta")]
public class Receta
{
    [Key]
    public int IdReceta { get; set; }
    public int IdCita { get; set; }
    [MaxLength(500)]
    public string? Diagnostico { get; set; }
    [MaxLength(500)]
    public string? Indicaciones { get; set; }
    public DateTime FechaEmision { get; set; } = DateTime.Now;

    [ForeignKey("IdCita")]
    public Cita? Cita { get; set; }
    public ICollection<DetalleReceta> Detalles { get; set; } = new List<DetalleReceta>();
}

[Table("DetalleReceta")]
public class DetalleReceta
{
    [Key]
    public int IdDetalle { get; set; }
    public int IdReceta { get; set; }
    public int IdMedicamento { get; set; }
    [MaxLength(100)]
    public string? Dosis { get; set; }
    [MaxLength(100)]
    public string? Frecuencia { get; set; }
    [MaxLength(50)]
    public string? Duracion { get; set; }
    public int Cantidad { get; set; } = 1;

    [ForeignKey("IdReceta")]
    public Receta? Receta { get; set; }
    [ForeignKey("IdMedicamento")]
    public Medicamento? Medicamento { get; set; }
}
