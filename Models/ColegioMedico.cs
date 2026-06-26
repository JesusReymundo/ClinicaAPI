using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("ColegioMedico")]
public class ColegioMedico
{
    [Key]
    public int IdColegioMedico { get; set; }
    public int IdMedico { get; set; }
    [Required, MaxLength(20)]
    public string Numero { get; set; } = string.Empty;
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
    public DateTime? FechaModificacion { get; set; }
    public int? IdUsuarioCreacion { get; set; }
    public int? IdUsuarioModificacion { get; set; }

    [ForeignKey("IdMedico")]
    public Medico? Medico { get; set; }
}
