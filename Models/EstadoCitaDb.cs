using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("EstadoCita")]
public class EstadoCitaDb
{
    [Key]
    [Column("IdEstadoCita")]
    public int IdEstado { get; set; }
    [Required, MaxLength(50)]
    public string Nombre { get; set; } = string.Empty;
}
